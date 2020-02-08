--メガリス・アンフォームド
--Megalith Unformed
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
s.listed_series={0x138}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)>0
		and Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsType,TYPE_RITUAL),tp,LOCATION_MZONE,LOCATION_MZONE,nil)>0
	local b2=s.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local stable={}
	local dtable={}
	if b1 then
		table.insert(stable,1)
		table.insert(dtable,aux.Stringid(id,0))
	end
	if b2 then
		table.insert(stable,2)
		table.insert(dtable,aux.Stringid(id,1))
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local op=stable[Duel.SelectOption(tp,table.unpack(dtable))+1]
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:SetOperation(s.atkop)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop)
		s.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local atk=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsType,TYPE_RITUAL),tp,LOCATION_MZONE,LOCATION_MZONE,nil)*(-500)
	if #g==0 or atk==0 then return end
	g:ForEach(s.op,e:GetHandler(),atk)
end
function s.op(tc,c,atk)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
function s.filter(c,e,tp,m,m2,ft)
	if not (c:IsSetCard(0x138) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true,POS_FACEUP_DEFENSE)) then return false end
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	mg:Merge(m2)
	if c.ritual_custom_condition then
		res=c:ritual_custom_condition(mg,ft,"equal")
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,nil)
	end
	if ft>0 then
		res=mg:CheckWithSumEqual(Card.GetRitualLevel,c:GetOriginalLevel()*2,1,99,c)
	else
		res=mg:IsExists(s.filterf,1,nil,tp,mg,c)
	end
	return res
end
function s.filterf(c,tp,mg,rc)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
		Duel.SetSelectedCard(c)
		return mg:CheckWithSumEqual(Card.GetRitualLevel,rc:GetOriginalLevel()*2,0,99,rc)
	else return false end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local mg=Duel.GetRitualMaterial(tp)
		local mg2=Group.CreateGroup()
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return ft>-1 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp,mg,mg2,ft)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetRitualMaterial(tp)
	local mg2=Group.CreateGroup()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mg,mg2,ft)
	local tc=tg:GetFirst()
	if tc then
		local mat=nil
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2)
		if tc.ritual_custom_operation then
			tc:ritual_custom_operation(mg,"equal")
			mat=tc:GetMaterial()
		else
			local lv=tc:GetOriginalLevel()*2
			if ft>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,lv,1,99,tc)
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				mat=mg:FilterSelect(tp,s.filterf,1,1,nil,tp,mg,tc)
				Duel.SetSelectedCard(mat)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				local mat2=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,lv,0,99,tc)
				mat:Merge(mat2)
			end
			tc:SetMaterial(mat)
		end
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP_DEFENSE)
		tc:CompleteProcedure()
	end
end

