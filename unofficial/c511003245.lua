--宝玉獣 エメラルド・タートル (Anime)
--Crystal Beast Emerald Tortoise (Anime)
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Change the position of 1 monster you control that attacked this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68215963,1))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--Place this card in Spell & Trap Zone instead of sending to GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.replacecon)
	e2:SetOperation(s.replaceop)
	c:RegisterEffect(e2)
end
function s.posfilter(c)
	return c:IsAttackPos() and c:GetAttackedCount()>0 and c:IsCanChangePosition()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local tc=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc)
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)
	end
end
function s.replacecon(e)
	local c=e:GetHandler()
	return ((c:IsFaceup() and c:IsLocation(LOCATION_MZONE)) or (c:IsLocation(LOCATION_HAND|LOCATION_DECK))) and c:IsReason(REASON_DESTROY)
end
function s.replaceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset((RESET_EVENT|RESETS_STANDARD)&~RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
	Duel.RaiseEvent(c,EVENT_CUSTOM+CARD_CRYSTAL_TREE,e,0,tp,0,0)
end