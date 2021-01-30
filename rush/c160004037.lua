--マグマックス・マントルヴェーダ
--Magmax Mantle-Ayurveda

local s,id=GetID()
function s.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.costfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PYRO) and c:IsAbleToGraveAsCost()
	and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel()) 
end
function s.desfilter(c,lvl)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsLevel(lvl)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	if Duel.SendtoGrave(tg,REASON_COST)==1 then
		local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,tg:GetFirst():GetLevel())
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end