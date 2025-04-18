--電脳堺悟－老々
--Virtual World Roshi - Laolao
--Scripted by Hel
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 card to the GY and Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_VIRTUAL_WORLD}
local key=TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP
function s.togravefilter(c,ctype)
	return c:IsSetCard(SET_VIRTUAL_WORLD) and not c:IsType(ctype&key) and c:IsAbleToGrave()
end
function s.tgfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_VIRTUAL_WORLD) and Duel.IsExistingMatchingCard(s.togravefilter,tp,LOCATION_DECK,0,1,nil,c:GetType())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.ssummonfilter(c,tgid,e,tp)
	return c:IsSetCard(SET_VIRTUAL_WORLD) and c:IsMonster() and not c:IsCode(tgid) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	--Cannot Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1),nil)
	--Send to GY and Special Summon
	if tc and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.togravefilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetType())
		if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
			local ogc=Duel.GetOperatedGroup():GetFirst()
			if ogc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
				--Special Summon from GY
				local gss=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.ssummonfilter),tp,LOCATION_GRAVE,0,nil,g:GetFirst():GetCode(),e,tp)
				if #gss>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local sg=gss:Select(tp,1,1,nil)
					if sg:GetFirst() and Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
						--Negate its effects
						local e2=Effect.CreateEffect(c)
						e2:SetType(EFFECT_TYPE_SINGLE)
						e2:SetCode(EFFECT_DISABLE)
						e2:SetReset(RESET_EVENT|RESETS_STANDARD)
						sg:GetFirst():RegisterEffect(e2,true)
						local e3=Effect.CreateEffect(c)
						e3:SetType(EFFECT_TYPE_SINGLE)
						e3:SetCode(EFFECT_DISABLE_EFFECT)
						e3:SetReset(RESET_EVENT|RESETS_STANDARD)
						sg:GetFirst():RegisterEffect(e3,true)
						Duel.SpecialSummonComplete()
					end
				end
			end
		end
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not (c:IsLevelAbove(3) or c:IsRankAbove(3))
end