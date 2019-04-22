--Nest of the Black Dragons
--designed by DavidKManner#3522, scripted by Naim
function c210777017.initial_effect(c)
	--fusion summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(210777017,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetTarget(c210777017.sptg2)
	e1:SetOperation(c210777017.spop2)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(210777017,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(c210777017.thtg)
	e2:SetOperation(c210777017.thop)
	c:RegisterEffect(e2)
	--gemini
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210777017,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e3:SetTarget(c210777017.gmmtg)
	e3:SetOperation(c210777017.gmmop)
	c:RegisterEffect(e3)
	--double damage (effect and battle)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetDescription(aux.Stringid(210777017,3))
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e4:SetOperation(c210777017.ddmgactivate)
	c:RegisterEffect(e4)
end
function c210777017.spfilter2(c,e)
	return not c:IsImmuneToEffect(e)
end
function c210777017.spfilter3(c,e,tp,m,g,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and g:IsExists(c210777017.spfilter4,1,nil,m,c,chkf)
end
function c210777017.redfilter(c)
	return c:IsSetCard(0x3b)
end
function c210777017.spfilter4(c,m,fusc,chkf)
	return fusc:CheckFusionMaterial(m,c,chkf)
end
function c210777017.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
	local g=Duel.GetMatchingGroup(c210777017.redfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
		if g:GetCount()==0 then return false end
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp)
		local res=Duel.IsExistingMatchingCard(c210777017.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,g,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(c210777017.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,g,mf,chkf)
			end
		end
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function c210777017.spop2(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c210777017.redfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
	g:Remove(Card.IsImmuneToEffect,nil,e)
	if g:GetCount()==0 then return false end
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(c210777017.spfilter2,nil,e)
	local sg1=Duel.GetMatchingGroup(c210777017.spfilter3,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,g,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(c210777017.spfilter3,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,g,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local ec=g:FilterSelect(tp,c210777017.spfilter4,1,1,nil,mg1,tc,chkf):GetFirst()
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,ec,chkf)
			tc:SetMaterial(mat1)
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
			local ec=g:FilterSelect(tp,c210777017.spfilter4,1,1,nil,mg2,tc,chkf):GetFirst()
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,ec,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
function c210777017.thfilter(c)
	return c:IsSetCard(0x3b) and c:IsLevelBelow(4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c210777017.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210777017.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210777017.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210777017.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c210777017.gmmfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x3b) and c:IsType(TYPE_DUAL) and not c:IsDualState()
end
function c210777017.gmmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210777017.gmmfilter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(c210777017.gmmfilter,tp,LOCATION_MZONE,0,nil)
	Duel.SetTargetCard(g)
end
function c210777017.gmmfilter2(c,e)
	return c:IsFaceup() and c:IsType(TYPE_DUAL) and c:IsSetCard(0x3b)  and not c:IsDualState() and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
function c210777017.gmmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c210777017.gmmfilter2,tp,LOCATION_MZONE,0,nil,e)
	local tc=g:GetFirst()
	while tc do
		tc:EnableDualState()
		tc:RegisterFlagEffect(210777017+100,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(210777017,4))
		tc=g:GetNext()
	end
end
c210777017[0]=0
c210777017[1]=0
function c210777017.ddmgactivate(e,tp,eg,ep,ev,re,r,rp)
	c210777017[tp]=1
	if Duel.GetFlagEffect(tp,210777017)~=0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetValue(c210777017.val)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetCondition(c210777017.rdcon)
	e2:SetOperation(c210777017.rdop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	Duel.RegisterFlagEffect(tp,210777017,RESET_PHASE+PHASE_END,0,1)
end
function c210777017.rdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:IsSetCard(0x3b) and tc:GetBattleTarget()~=nil
end
function c210777017.rdop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(ep,210777017)==0 then
		local dam2=Duel.GetBattleDamage(1-tp)
		Duel.DoubleBattleDamage(1-tp)
	end
end
function c210777017.val(e,re,dam,r,rp,rc)
    if bit.band(r,REASON_EFFECT)~=0 and re:GetHandler():IsSetCard(0x3b) then
        return dam*2
    else return dam end
end
function c210777017.value(e,re,dam,r,rp,rp)
	if r&REASON_EFFECT==REASON_EFFECT and re then
		local rc=re:GetHandler()
		if rc:IsSetCard(0x3b) then
			return dam*2
		else
			return dam
		end
	end
end
