--アディショナル・ミラー・レベル７
--Additional Mirror Level 7
--Made by Beetron-1 Beetletop
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.cfilter2(c)
	return c:IsCode(id) and c:IsAbleToGraveAsCost()
end
function s.cfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_DECK,0,2,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_DECK,0,2,2,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return #eg==1 and tc:IsLevel(7)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,2,nil,e,tp,tc:GetCode()) end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not tc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,2,2,nil,e,tp,tc:GetCode())
	if #g>0 then
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
      	    sg=Duel.GetOperatedGroup()
     		local tc=sg:GetFirst()
     		local atk=0
	     	while tc do
	     		local oatk=tc:GetAttack()
      			if oatk<0 then oatk=0 end
   	     		atk=atk+oatk
	     		tc=sg:GetNext()
	    	end
     		Duel.Damage(tp,atk,REASON_EFFECT)
	    end
	end
end