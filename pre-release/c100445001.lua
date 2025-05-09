--滅びの黒魔術師
--Dark Magician of Destruction
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: "Dark Magician" + 1 LIGHT or DARK monster
	Fusion.AddProcMix(c,true,true,CARD_DARK_MAGICIAN,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT|ATTRIBUTE_DARK))
	c:AddMustBeFusionSummoned()
	--You can only Fusion Summon or Special Summon by its alternate procedure "Dark Magician of Destruction" once per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--You can Special Summon this card by banishing 1 Level 6 or higher DARK Spellcaster monster you control during the turn a Spell Card or effect was activated
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.selfspcon)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Add 1 "Dark Magician" or 1 card that mentions it from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--This card's name becomes "Dark Magician" while on the field or in the GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e3:SetValue(CARD_DARK_MAGICIAN)
	c:RegisterEffect(e3)
	--Keep track of a turn a Spell Card or effect was activated
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,function(re,tp,cid) return not re:IsSpellEffect() end)
end
s.listed_names={CARD_DARK_MAGICIAN}
s.material_setcode=SET_DARK_MAGICIAN
function s.regcon(e)
	local c=e:GetHandler()
	return c:IsFusionSummoned() or c:IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	--Prevent another Fusion Summon or Special Summon by its alternate procedure of "Dark Magician of Destruction" that turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype) return c:IsOriginalCode(id) and (sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION or sumtype&SUMMON_TYPE_SPECIAL+1==SUMMON_TYPE_SPECIAL+1) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.selfspcostfilter(c,tp,sc)
	return c:IsLevelAbove(6) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.selfspcon(e,c)
	if not c then return true end
	local tp=c:GetControler()
	return (Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0 or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0)
		and Duel.IsExistingMatchingCard(s.selfspcostfilter,tp,LOCATION_MZONE,0,1,nil,tp,sc)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectMatchingCard(tp,s.selfspcostfilter,tp,LOCATION_MZONE,0,1,1,true,nil,tp,c)
	if g and #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end
function s.thfilter(c)
	return (c:IsCode(CARD_DARK_MAGICIAN) or c:ListsCode(CARD_DARK_MAGICIAN)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end