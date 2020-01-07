--Quiz Panel - Obelisk 10
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
s.collection={
	[12143771]=true;[58538870]=true;[85936485]=true;
}
function s.spfilter(c,e,tp)
	return c:IsCode(id+1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local endtime=0
	local check=true
	local start=os.time()
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4003,15))
	local ac1=Duel.AnnounceCard(1-tp)
	endtime=os.time()-start
	if endtime>10 or not s.collection[ac1] then
		check=false
	else
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4003,15))
		local ac2=Duel.AnnounceCard(1-tp)
		endtime=os.time()-start
		if endtime>10 or not s.collection[ac1] or ac1==ac2 then
			check=false
		else
			Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4003,15))
			local ac3=Duel.AnnounceCard(1-tp)
			endtime=os.time()-start
			if endtime>10 or not s.collection[ac1] or ac1==ac3 or ac3==ac2 then
				check=false
			end
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
