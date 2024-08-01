--Japanese name
--Mimighoul Cerberus
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--FLIP: Apply these effects in sequence
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Special Summon this card to your opponent's field in face-down Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.selfsptg)
	e2:SetOperation(s.selfspop)
	c:RegisterEffect(e2)
	--Your opponent cannot target face-up Spells you control with card effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(function(e,c) return c:IsSpell() end)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
	local c=e:GetHandler()
	if c:IsAbleToChangeControler() then
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,c,1,tp,0)
	end
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp,chk)
	local break_chk=false
	--Banish the top 3 cards of your Deck, then Special Summon 1 of your banished monsters to your opponent's field in Defense Position
	local g=Duel.GetDecktopGroup(tp,3)
	if #g>0 then
		break_chk=true
		Duel.DisableShuffleCheck()
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED)
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(sg,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
	end
	--Give control of this card to your opponent
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if break_chk then Duel.BreakEffect() end
		Duel.GetControl(c,1-tp)
	end
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(tp,c)
	end
end