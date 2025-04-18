--墓守の罠
--Gravekeeper's Trap
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Cannot activate effects or Special Summon from the GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.limcon)
	local e3=e2:Clone()
	e2:SetValue(function(_,re) return re:GetActivateLocation()==LOCATION_GRAVE end)
	c:RegisterEffect(e2)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTarget(function(_,c) return c:IsLocation(LOCATION_GRAVE) end)
	c:RegisterEffect(e3)
	--Search 1 "Gravekeeper's" or EARTH Fairy monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e4:SetCondition(function() return Duel.IsMainPhase() end)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--Declare card name
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PREDRAW)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetCondition(s.tgcon)
	e5:SetTarget(s.tgtg)
	e5:SetOperation(s.tgop)
	c:RegisterEffect(e5)
	--Check if normal draw has happened
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DRAW)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={CARD_EXCHANGE_SPIRIT}
s.listed_series={SET_GRAVEKEEPERS}
function s.limcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,CARD_EXCHANGE_SPIRIT)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD,nil)
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsMonster()
		and (c:IsSetCard(SET_GRAVEKEEPERS) or (c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_FAIRY)))
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
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp) and not Duel.IsPlayerAffectedByEffect(1-tp,EFFECT_CANNOT_DRAW)
		and Duel.GetDrawCount(1-tp)>0 and Duel.GetFlagEffect(1-tp,id)==0
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	e:SetLabel(Duel.AnnounceCard(tp,TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT))
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetDrawCount(1-tp)<1 then return end
	--Look at the drawn card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1)
	e1:SetOperation(s.drawcheck)
	e1:SetLabel(e:GetLabel())
	e1:SetReset(RESET_PHASE|PHASE_DRAW)
	Duel.RegisterEffect(e1,tp)
end
function s.drawcheck(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPhase(PHASE_DRAW) and (r&REASON_RULE)==REASON_RULE and #eg>0 then
		Duel.ConfirmCards(tp,eg)
		local dg=eg:Filter(Card.IsCode,nil,e:GetLabel())
		if #dg>0 then
			Duel.SendtoGrave(dg,REASON_EFFECT)
		end
		Duel.ShuffleHand(1-tp)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPhase(PHASE_DRAW) and (r&REASON_RULE)==REASON_RULE then
		Duel.RegisterFlagEffect(ep,id,RESET_PHASE|PHASE_STANDBY,0,1)
	end
end