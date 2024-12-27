--魔神火焔砲
--Obliterate!!! Blaze
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Grant effects to 1 monster you control with "Exodia" in its original name
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_EXODIA,SET_FORBIDDEN_ONE}
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(10) and c:IsOriginalSetCard(SET_EXODIA) and not c:HasFlagEffect(id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		Duel.HintSelection(tc,true)
		local c=e:GetHandler()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
		--Destroy cards in the Spell/Trap Zone and equip 5 "Forbidden One" monsters to this card
		local e1=Effect.CreateEffect(tc)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetCategory(CATEGORY_DESTROY+CATEGORY_EQUIP)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCost(s.descost)
		e1:SetTarget(s.destg)
		e1:SetOperation(s.desop)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		--Inflict piercing damage
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,Duel.GetLP(tp)//2)
end
function s.eqfilter(c,tp)
	return c:IsSetCard(SET_FORBIDDEN_ONE) and c:IsMonster() and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_STZONE,LOCATION_STZONE,1,nil)
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK,0,5,nil,tp) end
	local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_STZONE,LOCATION_STZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,5,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.GetMatchingGroup(nil,tp,LOCATION_STZONE,LOCATION_STZONE,nil)
	if Duel.Destroy(sg,REASON_EFFECT)>0 and c:IsFaceup() and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>=5
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK,0,5,nil,tp) then
		local eqg=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,tp)
		if #eqg>5 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			eqg=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK,0,5,5,nil,tp)
		end
		Duel.BreakEffect()
		for ec in eqg:Iter() do
			if Duel.Equip(tp,ec,c,true,true) then
				--The equipped monster gains 2000 ATK
				local e1=Effect.CreateEffect(ec)
				e1:SetType(EFFECT_TYPE_EQUIP)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(2000)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				ec:RegisterEffect(e1)
				--Equip limit
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e2:SetCode(EFFECT_EQUIP_LIMIT)
				e2:SetValue(function(e,c) return e:GetOwner()==c end)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD)
				ec:RegisterEffect(e2)
			end
		end
		Duel.EquipComplete()
	end
	local fid=c:GetFieldID()
	--You cannot activate cards and effects for the rest of this turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(1,0)
	e3:SetValue(function(_,re) return re:GetHandler()~=c or re:GetHandler():GetFieldID()~=fid end)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
end