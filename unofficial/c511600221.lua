--重力幻影
--Gravity Vision
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
   --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DEFCHANGE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={511009428}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.filter(c,tid)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_LINK)
		and c:GetLink()>0 and c:GetTurnID()==tid and c:IsReason(REASON_BATTLE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,Duel.GetTurnCount())
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,511009428,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_EARTH,POS_FACEUP) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,Duel.GetTurnCount())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,511009428,0,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_EARTH,POS_FACEUP) then
		local token=Duel.CreateToken(tp,511009428)
		local c=e:GetHandler()
		local oc=e:GetLabelObject()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local sc=g:GetFirst()
		if sc==oc then sc=g:GetNext() end
		if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0 then
			if sc and sc:IsRelateToEffect(e) then
				local def=sc:GetLink()*800
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_DEFENSE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(def)
				token:RegisterEffect(e1)
			end
			if oc and oc:IsFaceup() and oc:IsRelateToEffect(e) then
				token:CreateRelation(oc,RESET_EVENT+RESETS_STANDARD)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetLabelObject(token)
				e2:SetCondition(s.effcon)
				e2:SetValue(s.val)
				oc:RegisterEffect(e2)
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_MUST_ATTACK_MONSTER)
				e3:SetRange(LOCATION_MZONE)
				e3:SetLabelObject(token)
				e3:SetCondition(s.effcon)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				oc:RegisterEffect(e3)
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_FIELD)
				e4:SetCode(EFFECT_MUST_BE_ATTACKED)
				e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
				e4:SetRange(LOCATION_MZONE)
				e4:SetLabelObject(token)
				e4:SetCondition(s.effcon)
				e4:SetTarget(aux.TargetBoolFunction(s.cfilter))
				e4:SetValue(1)
				e4:SetReset(RESET_EVENT+RESETS_STANDARD)
				oc:RegisterEffect(e4)
			end
		end
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(511009428)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():IsRelateToCard(e:GetHandler())
end
function s.val(e,c)
	return -Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil):GetSum(Card.GetDefense)
end
