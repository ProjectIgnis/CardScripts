--歌舞伎舞台－大橋－
--Kabuki Stage - Big Bridge
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Special Summon 1 monster from the hand in face-up attack position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.con)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
	--Activate 1 "Kabuki Stage" card from the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(s.accost)
	e3:SetTarget(s.actg)
	e3:SetOperation(s.acop)
	c:RegisterEffect(e3)
end
s.listed_series={0x52e}
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.filter(c,tp)
	if not c:IsSetCard(0x52e) or c:IsMonster() or c:IsHasEffect(EFFECT_CANNOT_TRIGGER) then return false end
	local te=c:GetActivateEffect()
	local pre={Duel.GetPlayerEffect(tp,EFFECT_CANNOT_ACTIVATE)}
	if pre[1] then
		for i,eff in ipairs(pre) do
			local prev=eff:GetValue()
			if type(prev)~='function' or prev(eff,te,tp) then return false end
		end
	end
	return c:CheckActivateEffect(false,false,false)~=nil
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local tpe=tc:GetType()
		local te=tc:GetActivateEffect()
		local tg=te:GetTarget()
		local co=te:GetCost()
		local op=te:GetOperation()
		e:SetCategory(te:GetCategory())
		e:SetProperty(te:GetProperty())
		Duel.ClearTargetCard()
		local loc=LOCATION_SZONE
		if tpe&TYPE_FIELD~=0 then
			loc=LOCATION_FZONE
			local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
			if Duel.IsDuelType(DUEL_1_FIELD) then
				if fc then Duel.Destroy(fc,REASON_RULE) end
				fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
				if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
			else
				fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
				if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
			end
		end
		Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
		Duel.Hint(HINT_CARD,0,tc:GetCode())
		tc:CreateEffectRelation(te)
		if tpe&(TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
			tc:CancelToGrave(false)
		end
		if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
		if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if g then
			for etc in g:Iter() do
				etc:CreateEffectRelation(te)
			end
			local etc=g:GetFirst()
		end
		if op then op(te,tp,eg,ep,ev,re,r,rp) end
		tc:ReleaseEffectRelation(te)
		if g then
			for etc in g:Iter() do
				etc:ReleaseEffectRelation(te)
			end
		end
	end
end