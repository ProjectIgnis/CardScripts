--煉獄の虚夢
--Void Imagination
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--change level
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(1)
	e2:SetTarget(s.lvtg)
	c:RegisterEffect(e2)
	--reduce battle damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.rdcon)
	e3:SetOperation(s.rdop)
	c:RegisterEffect(e3)
	--spsummon
	local params = {aux.FilterBoolFunction(Card.IsSetCard,0xbb),nil,s.fextra}
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(s.spcost)
	e4:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e4:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e4)
	if not AshBlossomTable then AshBlossomTable={} end
	table.insert(AshBlossomTable,e4)
end
s.listed_series={0xbb}
function s.lvtg(e,c)
	return c:IsSetCard(0xbb) and c:GetOriginalLevel()>=2
end
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	local ac=eg:GetFirst()
	return ep~=tp and ac:IsControler(tp) and ac:IsSetCard(0xbb) and ac:GetOriginalLevel()>=2 and not ac:IsImmuneToEffect(e)
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.HalfBattleDamage(ep)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=6
end
function s.dmcon(tp)
	return not Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,LOCATION_MZONE,0,1,nil,LOCATION_EXTRA)
		and Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
end
function s.fextra(e,tp,mg)
	if s.dmcon(tp) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil),s.fcheck
	end
	return nil
end
