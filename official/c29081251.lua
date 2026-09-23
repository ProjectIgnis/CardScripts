--死相の冥鑑ヒュブロ
--Hubolt the Dark Directory of Death
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--You can Normal Summon this card without Tributing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(function(e,c,minc)
		if c==nil then return true end
		return minc==0 and c:IsLevelAbove(4) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
	end)
	c:RegisterEffect(e1)
	--If this card is Normal or Special Summoned: You can send 1 Level 6 or higher Zombie monster from your Deck to the GY, except "Hubolt the Dark Directory of Death", then you can add 1 Level 6 or higher Zombie monster from your GY to your hand
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetCountLimit(1,{id,0})
	e2a:SetTarget(s.tgtg)
	e2a:SetOperation(s.tgop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
	--If a monster(s) is Special Summoned from the GY while this card is in the Monster Zone, you can: Immediately after this effect resolves, Xyz Summon 1 Zombie Xyz Monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not eg:IsContains(e:GetHandler()) and eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_GRAVE)
	end)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
function s.tgfilter(c)
	return c:IsLevelAbove(6) and c:IsRace(RACE_ZOMBIE) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsLevelAbove(6) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE) then
		Duel.ShuffleDeck(tp)
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.BreakEffect()
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		end
	end
end
function s.xyzfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsXyzSummonable()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if sc then
		Duel.XyzSummon(tp,sc)
	end
end