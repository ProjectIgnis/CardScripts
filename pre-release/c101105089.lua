--
--Giant Beetrooper Invincible Atlas
--Scripted by DyXel

local s,id=GetID()
function s.initial_effect(c)
	--Link Summon.
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT),2)
	--Your opponent cannot target this card with card effects.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(s.indcon)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--It cannot be destroyed by your opponent's card effects.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	--Can only Special Summon Insect monsters.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(function(_,c,_,_,_)return not c:IsRace(RACE_INSECT)end)
	c:RegisterEffect(e3)
	--Special Summon OR Gain ATK.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.spatkcost)
	e4:SetTarget(s.spatktg)
	e4:SetOperation(s.spatkop)
	c:RegisterEffect(e4)
end
s.listed_series={0x26f}
function s.indcon(e)
	return e:GetHandler():IsAttackBelow(3000)
end
function s.cfilter(c,tp,tc,ft,spcheck)
	return c:IsRace(RACE_INSECT) and (c~=tc or (spcheck and (ft>0 or c:IsInMainMZone(tp))))
end
function s.spatkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local spcheck=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,tp,c,ft,spcheck) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,tp,c,ft,spcheck)
	Duel.Release(g,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x26f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local atk=e:GetHandler():IsLocation(LOCATION_MZONE)
	local spcheck=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local sel=-1
	if atk and spcheck then
		sel=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif spcheck then
		sel=Duel.SelectOption(tp,aux.Stringid(id,0))
	elseif atk then
		sel=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_ATKCHANGE)
	end
end
function s.spatkop(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g==0 then return end
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		--This card gains 2000 ATK until the end of this turn.
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END,1)
		e1:SetValue(2000)
		c:RegisterEffect(e1)
	end
end