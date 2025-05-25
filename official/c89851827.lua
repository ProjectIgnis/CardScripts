--聖秘なる竜騎士
--Sacramentum Dragoon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 Dragon monster + 1 Spellcaster monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER))
	--Loses 100 ATK for each of your banished cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e) return -100*Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_REMOVED,0) end)
	c:RegisterEffect(e1)
	--While you control this Fusion Summoned card, your opponent cannot activate the effects of Special Summoned Dragon and Spellcaster monsters they control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e2:SetValue(s.actlimval)
	c:RegisterEffect(e2)
	--Special Summon 1 Dragon or 1 Spellcaster monster from your GY and place the other on the bottom of the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptdtg)
	e3:SetOperation(s.sptdop)
	c:RegisterEffect(e3)
end
function s.actlimval(e,re,rp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and rc:IsSpecialSummoned() and rc:IsFaceup() and rc:IsRace(RACE_DRAGON|RACE_SPELLCASTER) and rc:IsLocation(LOCATION_MZONE)
end
function s.sptdfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON|RACE_SPELLCASTER) and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsAbleToDeck())
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsRace,1,nil,RACE_DRAGON) and sg:IsExists(Card.IsRace,1,nil,RACE_SPELLCASTER)
		and sg:IsExists(s.spchk,1,nil,e,tp,sg)
end
function s.spchk(c,e,tp,sg)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (#sg==1 or sg:IsExists(Card.IsAbleToDeck,1,c))
end
function s.sptdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.sptdfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,1,tp,0)
end
function s.sptdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if (#tg==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=tg:FilterSelect(tp,s.spchk,1,1,nil,e,tp,tg)
	if #sg>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 and #tg==2 then
		local dg=tg-sg
		Duel.HintSelection(dg)
		Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end