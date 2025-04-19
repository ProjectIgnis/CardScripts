--バーニング・ソニック
--Burning Sonic
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(function() Duel.NegateAttack() end)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabelObject(e1)
	e2:SetCondition(aux.PersistentTgCon)
	e2:SetOperation(aux.PersistentTgOp(true))
	c:RegisterEffect(e2)
	--While this card is in the Spell & Trap Zone, that monster gains 500 ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(aux.PersistentTargetFilter)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	--If that monster would be targeted by a Spell/Trap Card or effect, you can send this card to the Graveyard instead
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local tc=Duel.GetAttackTarget()
	if chk==0 then return tc and tc:IsOnField() and tc:IsControler(tp) and tc:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tc)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and re:IsSpellTrapEffect() and c:IsAbleToGrave()) then return end
	local tc=c:GetFirstCardTarget()
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if tc and tg and tg:IsContains(tc) and tc:IsLocation(LOCATION_MZONE) and Duel.SelectEffectYesNo(tp,c) then
		Duel.Hint(HINT_CARD,0,id)
		tc:ReleaseEffectRelation(re)
		Duel.SendtoGrave(c,REASON_EFFECT)
	end
end