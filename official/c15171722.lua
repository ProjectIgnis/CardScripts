--エヴォルダー・リオス
--Evolsaur Lios
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Set 1 "Evolutionary Bridge" or "Evo-Singularity" from the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Send 1 FIRE Reptile or Dinosaur monster to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_LVCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
	--Check if it's Special Summoned by a FIRE monster's effect
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3a:SetOperation(s.regop)
	c:RegisterEffect(e3a)
end
s.listed_names={93504463,74100225} --Evolutionary Bridge, Evo-Singularity
function s.setfilter(c)
	return c:IsCode(93504463,74100225) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsNormalSummoned() or (c:IsSpecialSummoned() and c:HasFlagEffect(id))
end
function s.tgfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_REPTILE|RACE_DINOSAUR) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.cfilter(c,lv,rac)
	return c:IsFaceup() and c:HasLevel() and (not c:IsRace(rac) or not c:IsLevel(lv))
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE) then
		local lv=sc:GetLevel()
		local rac=sc:GetRace()
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lv,rac)
		if #g>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
			local sg=g:FilterSelect(tp,s.cfilter,2,2,nil,lv,rac)
			Duel.HintSelection(sg,true)
			Duel.BreakEffect()
			local c=e:GetHandler()
			for tc in sg:Iter() do
				--Level becomes the sent monster's level
				if not tc:IsLevel(lv) then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CHANGE_LEVEL)
					e1:SetValue(lv)
					e1:SetReset(RESET_EVENT|RESETS_STANDARD)
					tc:RegisterEffect(e1)
				end
				--Type becomes the sent monster's type
				if not tc:IsRace(rac) then
					local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_CHANGE_RACE)
					e2:SetValue(rac)
					e2:SetReset(RESET_EVENT|RESETS_STANDARD)
					tc:RegisterEffect(e2)
				end
			end
		end
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if re and re:IsMonsterEffect() and re:GetHandler():IsAttribute(ATTRIBUTE_FIRE) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_LEAVE|RESET_TEMP_REMOVE),0,1)
	end
end