--ネオス・ワイズマン
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--special summon rule
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--damage&recover
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	--
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_NEOS}
function s.spfilter(c,...)
	return c:IsFaceup() and c:IsCode(...) and c:IsAbleToGraveAsCost()
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:IsExists(s.chk,1,nil,sg)
end
function s.chk(c,sg)
	return c:IsCode(CARD_NEOS) and sg:IsExists(Card.IsCode,1,c,78371393)
end
function s.spcon(e,c)
	if c==nil then return true end 
	local tp=c:GetControler()
	local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,CARD_NEOS)
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,78371393)
	local g=g1:Clone()
	g:Merge(g2)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and #g1>0 and #g2>0 
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_MZONE,0,nil,CARD_NEOS,78371393)
	local g=aux.SelectUnselectGroup(sg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttackTarget()~=nil end
	local bc=e:GetHandler():GetBattleTarget()
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,bc:GetDefense())
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	local atk=bc:GetAttack()
	local def=bc:GetDefense()
	if atk<0 then atk=0 end
	if def<0 then def=0 end
	Duel.Damage(1-tp,atk,REASON_EFFECT,true)
	Duel.Recover(tp,def,REASON_EFFECT,true)
	Duel.RDComplete()
end
