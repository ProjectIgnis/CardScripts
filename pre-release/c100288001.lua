--クロニクル・ソーサレス
--Chronicle Sorceress
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 card from Deck to GY, based on Attributes in GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
local BEWD,DM=CARD_BLUEEYES_W_DRAGON,CARD_DARK_MAGICIAN
	--Mentions "Blue-Eyes White Dragon" and "Dark Magician"
s.listed_names={BEWD,DM,id}

function s.codefilter(c,code)
	return not c:IsCode(id) and (c:IsCode(code) or aux.IsCodeListed(c,code)) and c:IsAbleToGrave()
end
	--Activation legality
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local light=Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_LIGHT)
	local dark=Duel.IsExistingMatchingCard(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_DARK)
	local b1=light and Duel.IsExistingMatchingCard(s.codefilter,tp,LOCATION_DECK,0,1,nil,BEWD)
	local b2=dark and Duel.IsExistingMatchingCard(s.codefilter,tp,LOCATION_DECK,0,1,nil,DM)
	if chk==0 then return b1 or b2 end
	local op=aux.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
	--Send 1 card from Deck to GY, based on attributes in GY
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	if e:GetLabel()==1 then
		g=Duel.SelectMatchingCard(tp,s.codefilter,tp,LOCATION_DECK,0,1,1,nil,BEWD)
	else
		g=Duel.SelectMatchingCard(tp,s.codefilter,tp,LOCATION_DECK,0,1,1,nil,DM)
	end
	if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end