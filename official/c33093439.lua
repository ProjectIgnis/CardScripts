--サイバー・エルタニン
--Cyber Eltanin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must be Special Summoned (from your hand) by banishing all LIGHT Machine monsters from your field and GY
	c:AddMustBeSpecialSummoned()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--If this card is Special Summoned: Send all other face-up monsters on the field to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
function s.spcostfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsFaceup() and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local locations=Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) and LOCATION_MZONE or LOCATION_MZONE|LOCATION_GRAVE
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,locations,0,nil)
	return #g>0 and Duel.GetMZoneCount(tp,g)>0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local locations=Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) and LOCATION_MZONE or LOCATION_MZONE|LOCATION_GRAVE
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,locations,0,nil)
	local banished_count=Duel.Remove(g,POS_FACEUP,REASON_COST)
	--This card's ATK/DEF become the number of monsters banished for its Special Summon x 500
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_SET_ATTACK)
	e1a:SetValue(banished_count*500)
	e1a:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE&~RESET_TOFIELD)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e1b)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,tp,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,exc)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end