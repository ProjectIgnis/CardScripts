--Ｅ．Ｍ．Ｒ．
--E.M.R.
--Scripted by DyXel
local s,id=GetID()
function s.initial_effect(c)
	--Tribute and destroy based on og ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK,TIMINGS_CHECK_MONSTER_E|TIMING_ATTACK)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desact)
	c:RegisterEffect(e1)
end
function s.costfilter(c,tc)
	return c:IsMonster() and c:IsRace(RACE_MACHINE) and c:GetTextAttack()>=1000
		and Duel.IsExistingTarget(nil,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(tc,c))
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,c)
	end
	local tg=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,c)
	local mtgc=tg:GetFirst():GetTextAttack()//1000
	Duel.Release(tg,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,mtgc,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desact(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end