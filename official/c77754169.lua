--超装甲兵器ロボ ブラックアイアンＧ
--Super Armored Robot Armed Black Iron "C"
--Updated by DyXel

local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself and equip.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Send equip and destroy.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.eqrfilter(c,code,e)
	return c:IsCode(code) and c:IsCanBeEffectTarget(e) and not c:IsForbidden()
end
function s.eqfilter(c,e,tp)
	return c:IsRace(RACE_INSECT) and c:IsCanBeEffectTarget(e) and not c:IsForbidden() and
		Duel.IsExistingMatchingCard(s.eqrfilter,tp,LOCATION_GRAVE,0,2,c,c:GetCode(),e)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==1
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		       Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and
		       e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and
		       Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	local ct=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),3)
	local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	local tg=aux.SelectUnselectGroup(g,e,tp,1,ct,s.rescon,1,tp,HINTMSG_EQUIP)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tg,#tg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local tg=Duel.GetTargetCards(e)
	local tgc=#tg
	if tgc==0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<tgc then return end
	Duel.BreakEffect()
	for tc in tg:Iter() do
		Duel.Equip(tp,tc,c,false)
		--Equip limit.
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.tgfilter(c,tp)
	return c:GetFlagEffect(id)~=0 and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetTextAttack())
end
function s.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local eqg=c:GetEquipGroup()
	if chk==0 then return eqg:IsExists(s.tgfilter,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=eqg:FilterSelect(tp,s.tgfilter,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetTextAttack())
	Duel.SendtoGrave(tc,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,e:GetLabel())
	Duel.Destroy(g,REASON_EFFECT)
end
