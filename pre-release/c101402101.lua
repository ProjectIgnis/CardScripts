--JP name
--Audhumla, Progenitor of the Frozen Expanse
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If 4 or more cards are on the field: You can Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)>=4
	end)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end)
	c:RegisterEffect(e1)
	--You can send up to 2 Spells/Traps you control to the GY; draw that many cards, then you can Special Summon 1 WATER monster from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	--When your opponent activates a card or effect (Quick Effect): You can change this card to face-down Defense Position, also for the rest of this turn, all face-down cards you control cannot be destroyed by your opponent's card effects, and your opponent cannot target them with card effects
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_SET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return ep==1-tp
	end)
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsSpellTrap,Card.IsAbleToGraveAsCost),tp,LOCATION_ONFIELD,0,1,nil) end
	local max_count=Duel.IsPlayerCanDraw(tp,2) and 2 or 1
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsSpellTrap,Card.IsAbleToGraveAsCost),tp,LOCATION_ONFIELD,0,1,max_count,nil)
	e:GetChainData().draw_count=#g
	Duel.SendtoGrave(g,REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local draw_count=e:GetChainData().draw_count
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,draw_count)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local draw_count=e:GetChainData().draw_count
	if Duel.Draw(tp,draw_count,REASON_EFFECT)==draw_count and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then
		if not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return Duel.ShuffleHand(tp) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,tp,POS_FACEDOWN_DEFENSE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,4))
	--Also for the rest of this turn, all face-down cards you control cannot be destroyed by your opponent's card effects, and your opponent cannot target them with card effects
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1a:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1a:SetTargetRange(LOCATION_ONFIELD,0)
	e1a:SetTarget(function(e,c)
		return c:IsFacedown()
	end)
	e1a:SetValue(aux.indoval)
	e1a:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1a,tp)
	local e1b=e1a:Clone()
	e1b:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1b:SetValue(aux.tgoval)
	Duel.RegisterEffect(e1b,tp)
end