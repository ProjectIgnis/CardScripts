--刻印を持つ者
--The Man with the Mark
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Take 1 "Temple of the Kings", or 1 Spell/Trap that mentions it, from your Deck and either add it to your hand or send it to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtgtg)
	e1:SetOperation(s.thtgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--While you control "Temple of the Kings", this card and "Apophis" monsters you control cannot be destroyed by battle or card effects
	--"Temple of the Kings" you control cannot be destroyed by card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_TEMPLE_OF_THE_KINGS),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil) end)
	e3:SetTarget(function(e,c) return c==e:GetHandler() or c:IsSetCard(SET_APOPHIS) end)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetTarget(function(e,c) return c==e:GetHandler() or (c:IsSetCard(SET_APOPHIS) and c:IsMonster()) or c:IsCode(CARD_TEMPLE_OF_THE_KINGS) end)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_TEMPLE_OF_THE_KINGS}
s.listed_series={SET_APOPHIS}
function s.thtgfilter(c)
	return (c:IsCode(CARD_TEMPLE_OF_THE_KINGS) or (c:IsSpellTrap() and c:ListsCode(CARD_TEMPLE_OF_THE_KINGS))) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.thtgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thtgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.thtgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectMatchingCard(tp,s.thtgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		aux.ToHandOrElse(g,tp)
	end
end