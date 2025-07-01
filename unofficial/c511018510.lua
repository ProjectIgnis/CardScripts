--ＲＵＭ－光波追撃
--Rank-Up-Magic Cipher Pursuit
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon from your Extra Deck, 1 "Cipher" Xyz Monster that is 1 Rank higher than 1 "Cipher" Xyz Monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41201386,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(function() return math.abs(Duel.GetLP(0)-Duel.GetLP(1))>=2000 end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_CIPHER}
function s.spfilter(c,e,tp,mc,rk,pg)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return c:IsType(TYPE_XYZ) and mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp)
		and c:IsRank(rk) and c:IsSetCard(SET_CIPHER) and mc:IsCanBeXyzMaterial(c,tp)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and (#pg<=0 or pg:IsContains(mc))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.matfilter(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return #pg<=1 and c:IsFaceup() and c:IsSetCard(SET_CIPHER) and c:HasRank()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1,pg)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.matfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e)
		or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e)
		or not tc:HasRank() then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,pg):GetFirst()
	if sc then
		sc:SetMaterial(tc)
		Duel.Overlay(sc,tc)
		--You can activate that Xyz Monster's effect that is activated by detaching its own Xyz Material(s)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetTarget(s.acttg)
		e1:SetOperation(s.actop)
		e1:SetReset(RESETS_STANDARD&~RESET_TOFIELD)
		sc:RegisterEffect(e1,true)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local effs={}
	for _,eff in ipairs({c:GetOwnEffects(id)}) do
		if eff:HasDetachCost() then table.insert(effs,eff) end
	end
	if chkc then
		for _,eff in ipairs(effs) do
			if eff:GetFieldID()==e:GetLabel() then return eff:GetTarget()(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
		end
		return false
	end
	local options={}
	local has_option=false
	for _,eff in ipairs(effs) do
		e:SetCategory(eff:GetCategory())
		e:SetProperty(eff:GetProperty())
		local con=eff:GetCondition()
		local cost=eff:GetCost()
		local tg=eff:GetTarget()
		local eff_chk=(not con or con(e,tp,eg,ep,ev,re,r,rp))
			and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0))
			and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0))
		if eff_chk then has_option=true end
		table.insert(options,{eff_chk,eff:GetDescription()})
	end
	e:SetCategory(0)
	e:SetProperty(0)
	if chk==0 then return has_option end
	local op=#options==1 and 1 or Duel.SelectEffect(tp,table.unpack(options))
	if not op then return end
	local te=effs[op]
	if not te then return end
	e:SetLabel(te:GetFieldID())
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	local cost=te:GetCost()
	if cost then cost(e,tp,eg,ep,ev,re,r,rp,1) end
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	te:UseCountLimit(tp)
	e:SetOperation(function(e,...)
		te:GetOperation()(e,...)
		e:Reset()
	end)
end
