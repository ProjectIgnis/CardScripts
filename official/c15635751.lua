--聖騎士と聖剣の巨城
--Camelot, Realm of Noble Knights and Noble Arms
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Destruction replacement for "Noble Knight" cards
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	--Banish this card, place 1 "Noble Knights of the Round Table" in your Field Zone and Special summon or add to hand 1 "Artorigus"/"Noble Arms" card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tofieldtg)
	e3:SetOperation(s.tofieldop)
	c:RegisterEffect(e3)
end
s.listed_names={55742055} --Noble Knights of the Round Table
s.listed_series={SET_NOBLE_KNIGHT,SET_NOBLE_ARMS,SET_ARTORIGUS}
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(SET_NOBLE_KNIGHT)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED|STATUS_BATTLE_DESTROYED)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,e) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local tc=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e):GetFirst()
		Duel.HintSelection(tc,true)
		e:SetLabelObject(tc)
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT|REASON_REPLACE)
end
function s.spfilter(c,e,tp,rmc)
	return c:IsSetCard(SET_TOPOLOGIC) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ((c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,rmc,c)>0)
		or (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp,rmc)>0))
end
function s.tofieldfilter(c)
	return c:IsCode(55742055) and not c:IsForbidden()
end
function s.tofieldtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and Duel.IsExistingMatchingCard(s.tofieldfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.cfilter(c,e,tp,ft)
	return (c:IsSetCard(SET_NOBLE_ARMS) and c:IsAbleToHand())
		or (ft>0 and c:IsSetCard(SET_ARTORIGUS) and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.tofieldop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and aux.RemoveUntil(c,nil,REASON_EFFECT,PHASE_STANDBY,id,e,tp,s.returnop) and c:IsLocation(LOCATION_REMOVED) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tofieldfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if not tc or not Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true) then return end
		--Special Summon 1 "Artorigus" monster, or add to your hand 1 "Noble Arms" card, from your Deck or GY
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.cfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,ft) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
			local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.cfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,ft):GetFirst()
			if not sc then return end
			local b1=ft>0 and sc:IsSetCard(SET_ARTORIGUS) and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			local b2=sc:IsSetCard(SET_NOBLE_ARMS) and sc:IsAbleToHand()
			Duel.BreakEffect()
			if b1 and b2 then
				aux.ToHandOrElse(sc,tp,
					function(sc) return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
					function(sc) Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
					aux.Stringid(id,3)
				)
			else
				if b1 then
					Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				elseif b2 then
					Duel.SendtoHand(sc,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,sc)
				end
			end
		end
	end
end
function s.returnop(rg,e,tp,eg,ep,ev,re,r,rp)
	local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fc then
		Duel.SendtoGrave(fc,REASON_RULE)
		Duel.BreakEffect()
	end
	Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
end