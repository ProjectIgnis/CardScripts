--リターン・オブ・ザ・ワールド
--Renewal of the World
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--ritual summon/to hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetLabelObject(e1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsRitualMonster() and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject():GetLabelObject()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if not tc or tc:IsFacedown() or tc:GetFlagEffect(id)==0 then return false end
		local b1=tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) 
			and Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,tc,e,tp,tc,ft)
		local b2=tc:IsAbleToHand()
		return b1 or b2
	end
	local b1=tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) 
		and Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,tc,e,tp,tc,ft)
	local b2=tc:IsAbleToHand()
	local sel=0
	if b1 and b2 then
		sel=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		sel=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		sel=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	if sel==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND)
		e:SetOperation(s.thop)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
	end
end
function s.relfilter(c,e,tp,tc,ft)
	local lv=tc:GetLevel()
	aux.RitualSummoningLevel=lv
	local mlv=c:GetRitualLevel(tc)
	aux.RitualSummoningLevel=nil
	if not ((mlv&0xffff)>=lv or (mlv>>16)>=lv) then return false end
	if tc.mat_filter and not tc.mat_filter(c) or (tc.ritual_custom_check and not tc.ritual_custom_check(e,tp,Group.FromCards(c),tc)) then return false end
	if c:IsLocation(LOCATION_GRAVE) then
		return c:IsType(TYPE_RITUAL) and ft>0 and c:IsAbleToDeck()
	else
		return (ft>0 or c:IsControler(tp)) and c:IsReleasableByEffect(e)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject():GetLabelObject()
	if not rc or rc:IsFacedown() or rc:GetFlagEffect(id)==0 then return end
	if not rc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.relfilter),tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,1,rc,e,tp,rc,ft):GetFirst()
	if tc then
		rc:SetMaterial(Group.FromCards(tc))
		if tc:IsLocation(LOCATION_GRAVE) then
			if Duel.SendtoDeck(tc,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)==0 then return end
		else
			if Duel.Release(tc,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)==0 then return end
		end
		Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		rc:CompleteProcedure()
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetLabelObject():GetLabelObject()
	if not rc or rc:IsFacedown() or rc:GetFlagEffect(id)==0 then return end
	Duel.SendtoHand(rc,nil,REASON_EFFECT)
end

