--JP name
--Angelechy Enlisted
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1 non-Tuner
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,1)
	--You can target 1 opponent's monster in this card's adjacent column; banish it, then change control of this card by moving it to one of your opponent's Main Monster Zones in this card's adjacent columns
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)
	--If the control of this face-up card changes: Return this card to the Extra Deck, then the owner of this card Special Summons 1 "Angelechy" monster from their Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CONTROL_CHANGED)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ANGELECHY}
function s.get_adjacent_zones(c)
	if not c:IsLocation(LOCATION_MZONE) then return 0 end
	local zones=0
	local seq=c:GetSequence()
	if seq==5 then seq=1 elseif seq==6 then seq=3 end
	if seq>0 then zones=1<<(5-seq) end --left zone
	if seq<4 then zones=zones|(1<<(3-seq)) end --right zone
	return zones
end
function s.banfilter(c,tp,zones)
	return c:IsMonster() and c:IsControler(1-tp) and c:IsAbleToRemove() and Duel.GetMZoneCount(1-tp,c,tp,LOCATION_REASON_CONTROL,zones)>0
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup(1,1):Sub(c:GetColumnGroup()):Match(s.banfilter,c,tp,s.get_adjacent_zones(c))
	if chkc then return cg:IsContains(chkc) end
	if chk==0 then return cg:IsExists(Card.IsCanBeEffectTarget,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=cg:FilterSelect(tp,Card.IsCanBeEffectTarget,1,1,nil,e)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,c,1,tp,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zones=s.get_adjacent_zones(c)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e)
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL,zones)>0 then
		Duel.BreakEffect()
		Duel.GetControl(c,1-tp,0,0,zones,tp)
	end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,c:GetOwner(),LOCATION_EXTRA)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ANGELECHY) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_EXTRA) then
		local owner=c:GetOwner()
		Duel.Hint(HINT_SELECTMSG,owner,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(owner,s.spfilter,owner,LOCATION_EXTRA,0,1,1,nil,e,owner)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,owner,owner,false,false,POS_FACEUP)
		end
	end
end