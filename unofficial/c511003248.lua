--宝玉獣 アンバー・マンモス (Anime)
--Crystal Beast Amber Mammoth (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--When another "Crystal Beast" monster you control is selected as an attack target, you can change the attack target to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69937550,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.attacktargetchangecon)
	e1:SetTarget(s.attacktargetchangetg)
	e1:SetOperation(s.attacktargetchangeop)
	c:RegisterEffect(e1)
	--Place this card in Spell & Trap Zone instead of sending to GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e2:SetCondition(s.replacecon)
	e2:SetOperation(s.replaceop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CRYSTAL_BEAST}
function s.attacktargetchangecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local at=eg:GetFirst()
	return r~=REASON_REPLACE and at~=c and at:IsFaceup() and at:IsSetCard(SET_CRYSTAL_BEAST) and at:GetControler()==c:GetControler()
end
function s.attacktargetchangetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttacker():GetAttackableTarget():IsContains(e:GetHandler()) end
end
function s.attacktargetchangeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and not Duel.GetAttacker():IsImmuneToEffect(e) then
		Duel.ChangeAttackTarget(c)
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