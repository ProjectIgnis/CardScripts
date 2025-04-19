--クリアー・ウォール (Anime)
--clear Wall (Anime)
--scripted by GameMaster + Shad3
--fixed by Larry126
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Destroy this card if "Clear World" is not on the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(function(e) return not Duel.IsEnvironment(CARD_CLEAR_WORLD) end)
	c:RegisterEffect(e2)
	--Faceup Attack Position "Clear" monsters you control cannot be destroyed by battle
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(function(e,c) return c:IsFaceup() and c:IsAttackPos() and c:IsClear() end)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--You take no damage from your "Clear" monsters if the battle damage is 1000 or less
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e4:SetCondition(s.rdcon1)
	e4:SetOperation(s.rdop1)
	c:RegisterEffect(e4)
	--If you would take 1000 or more damage from a battle involving a "Clear" monster you control, send this card to the GY 
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e5:SetCondition(s.rdcon2)
	e5:SetOperation(s.rdop2)
	c:RegisterEffect(e5)
end
s.listed_names={CARD_CLEAR_WORLD}
function s.rdcon1(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return Duel.GetBattleDamage(tp)<=1000
		and ((ac:IsControler(tp) and ac:IsFaceup() and ac:IsClear())
		or (at and at:IsControler(tp) and ac:IsFaceup() and at:IsClear()))
end
function s.rdop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,0)
end
function s.rdcon2(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return Duel.GetBattleDamage(tp)>1000
		and ((ac:IsControler(tp) and ac:IsFaceup() and ac:IsClear())
		or (at and at:IsControler(tp) and ac:IsFaceup() and at:IsClear()))
end
function s.rdop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(23857661,0)) then 
		Duel.ChangeBattleDamage(tp,0) 
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end