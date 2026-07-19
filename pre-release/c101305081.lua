--JP name
--Witness of the Ancient
--Scripted by The Razgriz
local s,id=GetID()
local TOKEN_ARC=id+100
function s.initial_effect(c)
	--If you have a Synchro Monster in your field or GY: You can Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If this card is Special Summoned: You can place up to 3 Synchro Monsters with different names from your Extra Deck and/or GY in your Spell & Trap Zone as face-up Continuous Spells, and Special Summon 1 "Arc Token" (Machine/LIGHT/ATK 0/DEF 0) with a Level equal to the number placed, also for the rest of this turn, you cannot Special Summon from the Extra Deck, except Synchro Monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_ARC} 
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSynchroMonster),tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.plfilter(c)
	return c:IsSynchroMonster() and not c:IsForbidden()
end
function s.rescon(tokenlv1chk,tokenlv2chk,tokenlv3chk,mzone_chk)
	return function(sg,e,tp,mg)
		if not mzone_chk then return sg:GetClassCount(Card.GetCode)==#sg end
		return (#sg==1 and tokenlv1chk)
			or (#sg==2 and tokenlv2chk)
			or (#sg==3 and tokenlv3chk),sg:GetClassCount(Card.GetCode)~=#sg
	end
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local stzone_count=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if stzone_count<=0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		local g=Duel.GetMatchingGroup(s.plfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,nil)
		if #g==0 then return false end
		local tokenlv1chk=stzone_count>=1 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ARC,0,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_LIGHT)
		local tokenlv2chk=stzone_count>=2 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ARC,0,TYPES_TOKEN,0,0,2,RACE_MACHINE,ATTRIBUTE_LIGHT)
		local tokenlv3chk=stzone_count>=3 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ARC,0,TYPES_TOKEN,0,0,3,RACE_MACHINE,ATTRIBUTE_LIGHT)
		return aux.SelectUnselectGroup(g,e,tp,1,math.min(3,stzone_count),s.rescon(tokenlv1chk,tokenlv2chk,tokenlv3chk,true),0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local stzone_count=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.plfilter),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,nil)
	if stzone_count>0 and #g>0 then
		local place_success_chk=false
		local mzone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local tokenlv1chk=stzone_count>=1 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ARC,0,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_LIGHT)
		local tokenlv2chk=stzone_count>=2 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ARC,0,TYPES_TOKEN,0,0,2,RACE_MACHINE,ATTRIBUTE_LIGHT)
		local tokenlv3chk=stzone_count>=3 and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ARC,0,TYPES_TOKEN,0,0,3,RACE_MACHINE,ATTRIBUTE_LIGHT)
		local rescon=s.rescon(tokenlv1chk,tokenlv2chk,tokenlv3chk,mzone_chk)
		local sg=aux.SelectUnselectGroup(g,e,tp,1,math.min(3,#g,stzone_count),rescon,1,tp,HINTMSG_TOFIELD,rescon)
		for sc in sg:Iter() do
			if Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
				place_success_chk=true
				--Treated as a Continuous Spell
				local e1=Effect.CreateEffect(c)
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
				sc:RegisterEffect(e1)
			end
		end
		if place_success_chk and mzone_chk then
			local token=Duel.CreateToken(tp,TOKEN_ARC)
			token:Level(#sg)
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	--For the rest of this turn, you cannot Special Summon from the Extra Deck, except Synchro Monsters
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSynchroMonster() end)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end