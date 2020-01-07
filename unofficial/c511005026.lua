--Breaking the Norm
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
  --Activation
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetCondition(s.cd)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.lv_fil(c,i)
	return c:GetLevel()==i and not c:IsType(TYPE_XYZ)
end
function s.cd(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local c=g:GetFirst()
	while c do
		if g:FilterCount(s.lv_fil,nil,c:GetLevel())>=3 then return true end
		c=g:GetNext()
		end
	return false
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local c=g:GetFirst()
	local lv=0
	while c do
		local i=c:GetLevel()
		if g:FilterCount(s.lv_fil,nil,i)>=3 then
		  lv=i
		  break
		end
		c=g:GetNext()
	end
	local dg=Duel.GetFieldGroup(1-tp,LOCATION_DECK,0)
	Duel.ConfirmCards(tp,dg)
	if lv>0 then
		local tg=dg:Filter(s.lv_fil,nil,lv):Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false):Select(tp,1,1,nil)
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end