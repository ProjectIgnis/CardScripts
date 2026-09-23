--白鴉の森の罪宝
--Sinful Spoils of the White Crow Forest
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--You can Special Summon this card (from your hand) by placing 1 Level 1 FIRE Monster Card from your face-up field or GY on the bottom of the Deck. You can only Special Summon "Sinful Spoils of the White Crow Forest" once per turn this way
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--When your opponent activates a card or effect (Quick Effect): You can return this card to the hand, then target 1 monster on the field (face-up) or in either GY; place it face-up in its owner's Spell & Trap Zone as a Continuous Spell. You can only use this effect of "Sinful Spoils of the White Crow Forest" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return ep==1-tp
	end)
	e2:SetCost(Cost.SelfToHand)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
end
function s.spcostfilter(c,tp)
	return c:IsLevel(1) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsMonsterCard() and c:IsFaceup()
		and c:IsAbleToDeckAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil,tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,nil,1,tp,HINTMSG_TODECK,nil,nil,true)
	if #sg>0 then
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if sg then
		Duel.HintSelection(sg)
		Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_COST)
	end
end
function s.plfilter(c)
	if not (c:IsMonster() and c:IsFaceup()) then return false end
	local owner=c:GetOwner()
	return Duel.GetLocationCount(owner,LOCATION_SZONE)>0 and c:CheckUniqueOnField(owner) and not c:IsForbidden()
end
local LOCATIONS_MZONE_GRAVE=LOCATION_MZONE|LOCATION_GRAVE
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATIONS_MZONE_GRAVE) and s.plfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.plfilter,tp,LOCATIONS_MZONE_GRAVE,LOCATIONS_MZONE_GRAVE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.plfilter,tp,LOCATIONS_MZONE_GRAVE,LOCATIONS_MZONE_GRAVE,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,tp,0)
	end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e)) then return end
	if Duel.GetLocationCount(tc:GetOwner(),LOCATION_SZONE)==0 then
		Duel.SendtoGrave(tc,REASON_RULE,nil,PLAYER_NONE)
	elseif Duel.MoveToField(tc,tp,tc:GetOwner(),LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
		--Treated as a Continuous Spell
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
		e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
		tc:RegisterEffect(e1)
	end
end