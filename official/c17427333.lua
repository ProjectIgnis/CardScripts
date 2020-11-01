--Ｅ．Ｍ．Ｒ．
--Electro-Magnetic Railgun
--Scripted by DyXel

DIDNT_SKIP_COST=0xDEADBEEF

local s,id=GetID()
function s.initial_effect(c)
	--Tribute and destroy based on og ATK
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_ATTACK,TIMINGS_CHECK_MONSTER_E+TIMING_ATTACK)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desact)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsMonster() and c:IsRace(RACE_MACHINE) and c:GetBaseAttack()>=1000
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(DIDNT_SKIP_COST)
	if chk==0 then return true end
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then
		if e:GetLabel()~=DIDNT_SKIP_COST then return false end
		return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil) and
		       Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
	end
	local tg=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil)
	local mtgc=tg:GetFirst():GetBaseAttack()//1000
	Duel.Release(tg,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,mtgc,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desact(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end
