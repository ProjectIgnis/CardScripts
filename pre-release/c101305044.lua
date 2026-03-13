--光と闇の儀式
--Ritual of Light and Darkness
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon 1 "Black Chaos the Dark Chaos Magician" or "Black Luster Soldier - Soldier of Light and Darkness" from your hand, by Tributing monsters from your hand or field, and/or banishing monsters from your GY, whose total Levels equal or exceed its Level
	Ritual.AddProcGreater{
			handler=c,
			filter=function(c) return c:IsCode(101305027,101305028) end,
			extrafil=function(e,tp) return Duel.GetMatchingGroup(aux.AND(Card.HasLevel,Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil) end,
			extratg=s.extratg,
			desc=aux.Stringid(id,0)
		}
	--If this card is in your GY: You can add both this card and 1 card that mentions "Ritual of Light and Darkness" from your GY to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={101305027,101305028,CARD_RITUAL_OF_LIGHT_AND_DARKNESS} --"Black Chaos the Dark Chaos Magician", "Black Luster Soldier - Soldier of Light and Darkness"
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:ListsCode(CARD_RITUAL_OF_LIGHT_AND_DARKNESS) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,c)
	if #g>0 then
		g:AddCard(c)
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end