--黄紡鮄デュオニギス
--Guitar Gurnards Duonigis
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Banish cards from the top of opponent's Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--Increase targeted monster's levels
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	--Increase targeted monster's ATK
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WATER),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=ct 
		and Duel.GetDecktopGroup(1-tp,ct):FilterCount(Card.IsAbleToRemove,nil)==ct end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WATER),tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	local g=Duel.GetDecktopGroup(1-tp,ct)
	if #g==ct then
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Increase Level
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(tc:GetOriginalLevel())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
local atkcfilter=aux.FaceupFilter(Card.IsMonster)
local atkfilter=aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WATER)
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(atkcfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(atkcfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	if ct==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g=Duel.SelectMatchingCard(tp,atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		--Increase ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*100)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		g:GetFirst():RegisterEffect(e1)
	end
end