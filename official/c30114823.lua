--コード・ジェネレーター
--Code Generator
--Scripted by AlphaKretin, extra material by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--If a Cyberse monster you control would be used as Link Material for a "Code Talker" monster, this card in your hand can also be used as material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(1,0)
	e1:SetOperation(s.extracon)
	e1:SetValue(s.extraval)
	c:RegisterEffect(e1)
	if s.flagmap==nil then
		s.flagmap={}
	end
	if s.flagmap[c]==nil then
		s.flagmap[c] = {}
	end
	--Send 1 Cyberse monster with 1200 or less ATK from your Deck to the GY, or, if this card on the field was used as material, you can add that card to your hand instead
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_CODE_TALKER}
function s.extrafilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return (sg+mg):Filter(s.extrafilter,nil,e:GetHandlerPlayer()):IsExists(Card.IsRace,1,og,RACE_CYBERSE) and sg:FilterCount(Card.HasFlagEffect,nil,id)<2
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not sc:IsSetCard(SET_CODE_TALKER) or Duel.HasFlagEffect(tp,id) then
			return Group.CreateGroup()
		else
			table.insert(s.flagmap[c],c:RegisterFlagEffect(id,0,0,1))
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK==SUMMON_TYPE_LINK and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		end
	elseif chk==2 then
		for _,eff in ipairs(s.flagmap[c]) do
			eff:Reset()
		end
		s.flagmap[c]={}
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_HAND|LOCATION_ONFIELD) and r==REASON_LINK and c:GetReasonCard():IsSetCard(SET_CODE_TALKER)
end
function s.tgfilter(c,tohand_chk)
	return c:IsRace(RACE_CYBERSE) and c:IsAttackBelow(1200) and (c:IsAbleToGrave() or (tohand_chk==1 and c:IsAbleToHand()))
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tohand_chk=e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,tohand_chk) end
	e:SetLabel(tohand_chk and 1 or 0)
	if not tohand_chk then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	else
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tohand_chk=e:GetLabel()==1
	local hint_msg=(tohand_chk and aux.Stringid(id,1) or HINTMSG_TOGRAVE)
	Duel.Hint(HINT_SELECTMSG,tp,hint_msg)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel()):GetFirst()
	if not sc then return end
	if tohand_chk then
		aux.ToHandOrElse(sc,tp)
	else
		Duel.SendtoGrave(sc,REASON_EFFECT)
	end
end
