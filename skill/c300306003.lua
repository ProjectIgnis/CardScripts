--Vampiric Aristocracy
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_series={SET_VAMPIRE}
s.listed_names={53839837,22056710}
function s.cfilter(c)
	return c:IsMonster() and c:IsRace(RACE_ZOMBIE) and c:IsFaceup() and not c:IsCode(53839837)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) 
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--OPD Register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Change Zombie monster to "Vampire Lord"
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(53839837)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	--"Vampire Genesis" GY Set effect
	local ea=Effect.CreateEffect(c)
	ea:SetDescription(aux.Stringid(id,0))
	ea:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	ea:SetCode(EVENT_BATTLE_DAMAGE)
	ea:SetRange(LOCATION_MZONE)
	ea:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	ea:SetCondition(s.gycon)
	ea:SetTarget(s.gytg)
	ea:SetOperation(s.gyop)
	local eb=Effect.CreateEffect(c)
	eb:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	eb:SetRange(0x5f)
	eb:SetTargetRange(LOCATION_MZONE,0)
	eb:SetTarget(function(e,c) return c:IsCode(22056710) and c:IsFaceup() end)
	eb:SetLabelObject(ea)
	Duel.RegisterEffect(eb,tp)
end
function s.gyfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and ((c:IsSpellTrap() and c:IsSSetable(true))
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,tp))
end
function s.rescon(sg,e,tp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_GRAVE,0)
	if #g==0 then return end
	local c=g:GetFirst()
	if c:IsMonster() then return Duel.GetMZoneCount(tp,c1)>0 end
	return (c:IsSpell() and c:IsType(TYPE_FIELD))
		or Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		or (c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5)
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.gyfilter,tp,0,LOCATION_GRAVE,nil,e,tp)
	if chk==0 then return #g>0 and aux.SelectUnselectGroup(g,e,tp,1,1,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,1,s.rescon,1,tp,HINTMSG_TARGET)
	local tc=tg:GetFirst()
	Duel.SetTargetCard(tc)
	local cat=e:GetCategory()
	if tc:IsMonster() then
		e:SetCategory(cat|CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
	else
		e:SetCategory(cat&~CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
	end
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsMonster() and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.SpecialSummon(sc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
			Duel.ConfirmCards(1-tp,sc)
	elseif tc:IsType(TYPE_SPELL+TYPE_TRAP) and tc:IsSSetable() then
			Duel.SSet(tp,tc,tp)
	end
end
