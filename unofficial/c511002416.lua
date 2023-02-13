--ーク・アイズ・イリュージョニスト (Anime)
--Dark-Eyes Illusionist (Anime)
--scripted by GameMaster(GM)
--Rescripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Negate attack and prevent monster from attacking while on field
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATEATTACK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local a=Duel.GetAttacker()
	Duel.SetOperationInfo(0,CATEGORY_NEGATEATTACK,a,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if Duel.NegateAttack() and tc and tc:IsFaceup() then
		Duel.NegateAttack()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
