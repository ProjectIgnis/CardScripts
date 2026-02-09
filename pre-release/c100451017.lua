--サイバース・コード・マジシャン
--Cyberse Code Magician
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--If a Link Monster you control would be used as Link Material for a Cyberse monster, this card in your hand can also be used as material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_EXTRA_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(1,0)
	e1:SetOperation(s.extracon)
	e1:SetValue(s.extraval)
	c:RegisterEffect(e1)
	if s.flagmap1==nil then
		s.flagmap1={}
	end
	if s.flagmap1[c]==nil then
		s.flagmap1[c] = {}
	end
	--If this card is sent from the hand or field to the GY: You can send 1 Cyberse monster from your Deck to the GY, or if this Ritual Summoned card was sent to the GY, you can Special Summon that monster instead, also in either case, you cannot Special Summon for the rest of this turn, except Cyberse monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_HAND|LOCATION_ONFIELD) end)
	e2:SetTarget(s.tgsptg)
	e2:SetOperation(s.tgspop)
	c:RegisterEffect(e2)
end
s.listed_names={34767865} --"Cynet Ritual"
function s.extrafilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.extracon(c,e,tp,sg,mg,lc,og,chk)
	return (sg+mg):Filter(s.extrafilter,nil,e:GetHandlerPlayer()):IsExists(Card.IsLinkMonster,1,og) and
	sg:FilterCount(Card.HasFlagEffect,nil,id)<2
end
function s.extraval(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type~=SUMMON_TYPE_LINK or not sc:IsRace(RACE_CYBERSE) or Duel.GetFlagEffect(tp,id)>0 then
			return Group.CreateGroup()
		else
			table.insert(s.flagmap1[c],c:RegisterFlagEffect(id,0,0,1))
			return Group.FromCards(c)
		end
	elseif chk==1 then
		local sg,sc,tp=...
		if summon_type&SUMMON_TYPE_LINK == SUMMON_TYPE_LINK and #sg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		end
	elseif chk==2 then
		for _,eff in ipairs(s.flagmap1[c]) do
			eff:Reset()
		end
		s.flagmap1[c]={}
	end
end
function s.tgspfilter(c,e,tp,mmz_ritsum_chk)
	return c:IsRace(RACE_CYBERSE) and (c:IsAbleToGrave() or (mmz_ritsum_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.tgsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ritual_summoned_chk=e:GetHandler():IsRitualSummoned()
	if chk==0 then
		local mmz_ritsum_chk=ritual_summoned_chk and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		return Duel.IsExistingMatchingCard(s.tgspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,mmz_ritsum_chk)
	end
	if not ritual_summoned_chk then
		e:SetLabel(0)
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	else
		e:SetLabel(1)
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
function s.tgspop(e,tp,eg,ep,ev,re,r,rp)
	local mmz_ritsum_chk=e:GetLabel()==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local hint=mmz_ritsum_chk and aux.Stringid(id,1) or HINTMSG_TOGRAVE
	Duel.Hint(HINT_SELECTMSG,tp,hint)
	local sc=Duel.SelectMatchingCard(tp,s.tgspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mmz_ritsum_chk):GetFirst()
	if sc then
		local op=nil
		if not mmz_ritsum_chk then
			op=1
		else
			local b1=sc:IsAbleToGrave()
			local b2=sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			op=Duel.SelectEffect(tp,
				{b1,aux.Stringid(id,2)},
				{b2,aux.Stringid(id,3)})
		end
		if op==1 then
			Duel.SendtoGrave(sc,REASON_EFFECT)
		elseif op==2 then
			Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	--You cannot Special Summon for the rest of this turn, except Cyberse monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsRaceExcept(RACE_CYBERSE) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end