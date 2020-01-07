--Quiz Panel - Ra 10
os = require('os')
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(51102781,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsCode(id+1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local endtime=0
	local check=true
	local start=os.time()
	local ct=0
	local ac
	repeat
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4006,6))
		ac=Duel.AnnounceCard(1-tp)
		endtime=os.time()-start
		ct=ct+1
		if endtime>10 or ac~=49003308 then
			check=false
		end
	until check==false or ct>=3
	if check==true then
		ct=0
		repeat
			Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4006,6))
			ac=Duel.AnnounceCard(1-tp)
			endtime=os.time()-start
			ct=ct+1
			if endtime>10 or ac~=43793530 then
				check=false
			end
		until check==false or ct>=3
		if check==true then
			ct=0
			repeat
				Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4006,6))
				ac=Duel.AnnounceCard(1-tp)
				endtime=os.time()-start
				ct=ct+1
				if endtime>10 or ac~=39674352 then
					check=false
				end
			until check==false or ct>=3
		end
	end
	Duel.BreakEffect()
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,0x13,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
	if check==true then
		Duel.Damage(tp,500,REASON_EFFECT)
	else
		if Duel.GetAttacker() then
			Duel.Destroy(Duel.GetAttacker(),REASON_EFFECT)
		end
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
