--Ａ宝玉獣 アンバー・マンモス (Anime)
--Advanced Crystal Beast Amber Mammoth (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Treated as "Crystal Beast Amber Mammoth"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetValue(69937550)
	c:RegisterEffect(e0)
	--Destroy this card if "Advanced Dark" is not on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return not Duel.IsEnvironment(CARD_ADVANCED_DARK) end)
	c:RegisterEffect(e1)
	--When another "Crystal Beast" monster you control is selected as an attack target, you can change the attack target to this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69937550,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.attacktargetchangecon)
	e2:SetTarget(s.attacktargetchangetg)
	e2:SetOperation(s.attacktargetchangeop)
	c:RegisterEffect(e2)
	--When this card is destroyed, you can place it in the Spell & Trap Zone as a Continuous Spell instead of sending it to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e3:SetCondition(s.replacecon)
	e3:SetOperation(s.replaceop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_CRYSTAL_BEAST}
s.listed_names={CARD_ADVANCED_DARK,69937550} --"Crystal Beast Amber Mammoth"
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
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
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
