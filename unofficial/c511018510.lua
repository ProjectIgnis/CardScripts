--ＲＵＭ－光波追撃
--Rank-Up-Magic Cipher Pursuit
--cleaned up by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local re1=Effect.CreateEffect(c)
	re1:SetDescription(aux.Stringid(41201386,0))
	re1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	re1:SetType(EFFECT_TYPE_ACTIVATE)
	re1:SetCode(EVENT_FREE_CHAIN)
	re1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	re1:SetCondition(s.condition)
	re1:SetTarget(s.target)
	re1:SetOperation(s.activate)
	c:RegisterEffect(re1)
end
s.listed_series={0xe5}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))>=2000
end
function s.filter1(c,e,tp)
	local rk=c:GetRank()
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return #pg<=1 and c:IsFaceup() and c:IsSetCard(0xe5) and (rk>0 or c:IsStatus(STATUS_NO_LEVEL))
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1,pg)
end
function s.filter2(c,e,tp,mc,rk,pg)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return c:IsType(TYPE_XYZ) and mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsRank(rk) and c:IsSetCard(0xe5) and mc:IsCanBeXyzMaterial(c,tp)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and (#pg<=0 or pg:IsContains(mc))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return end
	local tc=Duel.GetFirstTarget()
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,pg)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(tc)
		Duel.Overlay(sc,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetTarget(s.tg)
		e1:SetOperation(s.op)
		e1:SetReset(RESETS_STANDARD&~RESET_TOFIELD)
		sc:RegisterEffect(e1,true)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		if not c:IsHasEffect(id) then return false end
		local tgeffs={c:GetCardEffect(id)}
		for _,tge in ipairs(tgeffs) do
			if tge:GetLabel()==ev then return tge:GetLabelObject():GetTarget()(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
		end
		return false
	end
	if chk==0 then
		if not c:IsHasEffect(511002571) then return false end
		local effs={c:GetCardEffect(511002571)}
		for _,teh in ipairs(effs) do
			local temp=teh:GetLabelObject()
			if temp:GetCode()&511001822==511001822 or temp:GetLabel()==511001822 then temp=temp:GetLabelObject() end
			e:SetCategory(temp:GetCategory())
			e:SetProperty(temp:GetProperty())
			local con=temp:GetCondition()
			local cost=temp:GetCost()
			local tg=temp:GetTarget()
			if (not con or con(e,tp,eg,ep,ev,re,r,rp))
				and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0))
				and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)) then
				return true
			end
		end
		return false
	end
	local effs={c:GetCardEffect(511002571)}
	local acd={}
	local ac={}
	for _,teh in ipairs(effs) do
		local temp=teh:GetLabelObject()
		if temp:GetCode()&511001822==511001822 or temp:GetLabel()==511001822 then temp=temp:GetLabelObject() end
		e:SetCategory(temp:GetCategory())
		e:SetProperty(temp:GetProperty())
		local con=temp:GetCondition()
		local cost=temp:GetCost()
		local tg=temp:GetTarget()
		if (not con or con(e,tp,eg,ep,ev,re,r,rp))
			and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0))
			and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)) then
			table.insert(ac,teh)
			table.insert(acd,temp:GetDescription())
		end
	end
	local te=nil
	if #ac==1 then te=ac[1] elseif #ac>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		local op=Duel.SelectOption(tp,table.unpack(acd))+1
		te=ac[op]
	end
	local teh=te
	te=teh:GetLabelObject()
	if te:GetCode()&511001822==511001822 or te:GetLabel()==511001822 then te=te:GetLabelObject() end
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	local cost=te:GetCost()
	if cost then cost(e,tp,eg,ep,ev,re,r,rp,1) end
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1,chkc) end
	te:UseCountLimit(tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(id)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetLabel(Duel.GetCurrentChain())
	e1:SetLabelObject(te)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsHasEffect(id) then
		local tgeffs={c:GetCardEffect(id)}
		for _,tge in ipairs(tgeffs) do
			if tge:GetLabel()==Duel.GetCurrentChain() then
				local te=tge:GetLabelObject()
				local operation=te:GetOperation()
				if operation then operation(e,tp,eg,ep,ev,re,r,rp) end
			end
		end
	end
	e:Reset()
end
