--完全なる羽化－究極完全態・グレート・モス
--Perfect Eclosion - Perfectly Ultimate Great Moth
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must be Special Summoned (from your hand) by having 6 or more Insect monsters in your GY. You can only Special Summon "Perfect Eclosion - Perfectly Ultimate Great Moth" once per turn this way
	c:AddMustBeSpecialSummoned()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(function(e,c)
		if c==nil then return true end
		local tp=c:GetControler()
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,6,nil,RACE_INSECT)
	end)
	c:RegisterEffect(e0)
	--If this card is Special Summoned: You can return as many cards your opponent controls as possible to the hand, then if you have a Normal Monster in your GY, you can make this card gain 300 ATK for each Insect monster in your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.rthtg)
	e1:SetOperation(s.rthop)
	c:RegisterEffect(e1)
	--Each time your opponent Normal or Special Summons a monster(s): All monsters your opponent currently controls lose ATK equal to their own Level x 100
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,2))
	e2a:SetCategory(CATEGORY_ATKCHANGE)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCondition(s.atkcon)
	e2a:SetOperation(s.atkop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end
s.listed_names={id}
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and Duel.GetOperatedGroup():IsExists(Card.IsLocation,1,nil,LOCATION_HAND)
		and c:IsRelateToEffect(e) and c:IsFaceup()
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_NORMAL) then
		local gc=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_INSECT)
		if gc>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			--If you have a Normal Monster in your GY, you can make this card gain 300 ATK for each Insect monster in your GY
			c:UpdateAttack(gc*300)
		end
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.HasLevel),tp,0,LOCATION_MZONE,nil)
	for tc in g:Iter() do
		--All monsters your opponent currently controls lose ATK equal to their own Level x 100
		tc:UpdateAttack(tc:GetLevel()*-100,nil,c)
	end
end