--尾長黒馬
--Long-Tailed Black Horse
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can reveal 1 Zombie monster in your hand and send 1 EARTH Zombie monster from your Deck to the GY; send the revealed monster to the GY, and if you do, this card gains 500 ATK until the end of this turn. You can only use this effect of "Long-Tailed Black Horse" once per turn
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetCost(Cost.AND(Cost.Reveal(s.revealfilter,false,1,1,s.revealcostop),s.tgcost))
	e1a:SetTarget(s.tgtg)
	e1a:SetOperation(s.tgop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
end
function s.revealfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
function s.revealcostop(e,tp,g)
	local rc=g:GetFirst()
	e:SetLabelObject(rc)
	rc:CreateEffectRelation(e)
end
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGraveAsCost()
end
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetLabelObject(),1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,500)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=e:GetLabelObject()
	if rc:IsRelateToEffect(e) and Duel.SendtoGrave(rc,REASON_EFFECT) and rc:IsLocation(LOCATION_GRAVE)
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		--This card gains 500 ATK until the end of this turn
		c:UpdateAttack(500,RESETS_STANDARD_DISABLE_PHASE_END)
	end
end