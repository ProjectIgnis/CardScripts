--ハイブリッドライブ・スケイル
--Hybridrive Scale
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c,att,race)
	return c:IsMonster() and c:IsAttribute(att) and c:IsRace(race)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_EARTH,RACE_MACHINE)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_LIGHT,RACE_DRAGON)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)==0 then return end
	e:GetHandler():AddDoubleTribute(id,s.otfilter,s.eftg,RESETS_STANDARD_PHASE_END,FLAG_DOUBLE_TRIB_DRAGON,FLAG_DOUBLE_TRIB_MACHINE)
end
function s.otfilter(c,tp)
	return c:IsDoubleTribute(FLAG_DOUBLE_TRIB_DRAGON,FLAG_DOUBLE_TRIB_MACHINE) and (c:IsControler(tp) or c:IsFaceup())
end
function s.eftg(e,c)
	return c:IsRace(RACE_DRAGON|RACE_MACHINE) and c:IsLevelAbove(7) and c:IsSummonableCard()
end
