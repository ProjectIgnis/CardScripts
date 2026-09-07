--Ｔｈｅ ｄｅｓｐａｉｒ ＵＲＡＮＵＳ
--The Despair Uranus
local s,id=GetID()
function s.initial_effect(c)
	--Your opponent declares either Continuous Spell or Continuous Trap, then you Set 1 card of that type from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(function(e,tp) return e:GetHandler():IsTributeSummoned() and not Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,0,1,nil) end)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--This card gains 300 ATK for each face-up Spell/Trap you control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(function(e,c) return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSpellTrap),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*300 end)
	c:RegisterEffect(e2)
	--Face-up cards in your Spell & Trap Zone cannot be destroyed by card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_STZONE,0)
	e3:SetTarget(function(e,c) return c:IsFaceup() end)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
function s.setfilter(c)
	return c:IsContinuousSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local op=Duel.SelectOption(1-tp,aux.Stringid(id,1),aux.Stringid(id,2))
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	local filter=op==0 and Card.IsContinuousSpell or Card.IsContinuousTrap
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sg=g:FilterSelect(tp,filter,1,1,nil)
	if #sg>0 then
		Duel.SSet(tp,sg)
	end
end