--幻壊融門スクラップゲート
--Demolition Fusegate Scrapegate
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Can also shuffle monsters from your GY as Fusion Material for the Fusion Summon using "Fusion"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e2:SetTarget(aux.TargetBoolFunction(s.extrafil_repl_filter))
	e2:SetOperation(Fusion.ShuffleMaterial)
	e2:SetLabelObject({s.extrafil_replacement,s.extramat})
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsRace(RACE_WYRM) and c:IsLevelAbove(7)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.extrafil_repl_filter(c)
    return c:IsMonster() and c:IsAbleToDeck() and c:IsRace(RACE_WYRM)
end
function s.extrafil_replacement(e,tp,mg)
    return Duel.GetMatchingGroup(aux.NecroValleyFilter(s.extrafil_repl_filter),tp,LOCATION_GRAVE,0,nil)
end
function s.extramat(c,e,tp)
    return c:IsControler(tp) and e:GetHandler():IsCode(CARD_FUSION)
end