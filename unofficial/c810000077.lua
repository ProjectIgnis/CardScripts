--水照明 (Anime)
--Aquarium Lighting (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Double ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_AQUAACTRESS}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc,bt=Duel.GetBattleMonster(tp)
	if not tc then return false end
	e:SetLabelObject(tc)
	return bt and tc:IsFaceup() and tc:IsSetCard(SET_AQUAACTRESS)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if not tc:IsRelateToBattle() or tc:IsFacedown() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE_CAL)
	e1:SetValue(tc:GetAttack()*2)
	tc:RegisterEffect(e1)
end