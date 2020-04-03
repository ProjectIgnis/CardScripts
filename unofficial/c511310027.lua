--フェニックス・ギア・ブレード
--Phoenix Gearblade
--Scripted by AlphaKretin
local card, code = GetID()
function card.initial_effect(c)
	aux.AddEquipProcedure(c, nil, aux.FilterBoolFunction(Card.IsRace, RACE_WARRIOR))
	--Atk up
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--Repeat attack
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(code, 0))
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(card.racon)
	e2:SetCost(card.racost)
	e2:SetOperation(card.raop)
	c:RegisterEffect(e2)
end

function card.racon(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():GetEquipTarget() == eg:GetFirst()
end

function card.racost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return e:GetHandler():IsAbleToGraveAsCost()
	end
	Duel.SendtoGrave(e:GetHandler(), REASON_COST)
end

function card.rafilter(e, c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)
end

function card.raop(e, tp, eg, ep, ev, re, r, rp)
	--atk
	local e1 = Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE, 0)
	e1:SetTarget(card.rafilter)
	e1:SetReset(RESET_PHASE + PHASE_END)
	e1:SetValue(1)
	Duel.RegisterEffect(e1, tp)
end
