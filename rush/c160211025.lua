--結束の戦士マグネット・バルキリオン
--Valkyrion the Unity Warrior
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Material
	Fusion.AddProcMix(c,true,true,99785935,39256679,11549357)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={99785935,39256679,11549357}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
end
function s.filter(c,e,tp)
	return c:IsCode(99785935,39256679,11549357) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>=3 and aux.SelectUnselectGroup(g,e,tp,3,3,aux.dpcheck(Card.GetCode),0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.SendtoGrave(c,REASON_COST)<1 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local cg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dpcheck(Card.GetCode),1,tp,HINTMSG_SPSUMMON)
	if #cg>0 then
		Duel.SpecialSummon(cg,0,tp,tp,false,false,POS_FACEUP)
	end
end
