--月光舞豹姫 (Anime)
--Lunalight Panther Dancer (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fustion Materials
	Fusion.AddProcMix(c,true,true,51777272,aux.FilterBoolFunction(Card.IsSetCard,SET_LUNALIGHT))
	--Cannot be destroyed by your opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	--This card can attack all monsters your opponent controls, twice each
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(2)
	c:RegisterEffect(e2)
	--The opponent's monsters cannot be destroyed by the first attack of this card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.indtg)
	e3:SetValue(s.indct)
	c:RegisterEffect(e3)
	--This card gains 200 ATK until the end of the Battle Phase
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLED)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
s.listed_names={51777272}
s.listed_series={SET_LUNALIGHT}
s.material_setcode=SET_LUNALIGHT
function s.indtg(e,c)
	local hc=e:GetHandler()
	return c:GetReasonCard()==hc and Duel.GetAttacker()==hc
end
function s.indct(e,re,r,rp,c)
	if (r&REASON_BATTLE)>0 then
		return 1
	else return 0 end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and c:IsStatus(STATUS_OPPO_BATTLE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() and c:IsFaceup() and not c:IsStatus(STATUS_BATTLE_DESTROYED) then
		--Gains 200 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end