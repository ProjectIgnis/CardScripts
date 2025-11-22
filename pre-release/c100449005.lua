--海老須神鮮まつり
--Ebisu Shinsen Matsuri
--scripted by pyrQ
local s,id=GetID()
local TOKEN_SHINSEN=id+100
local TOKEN_EBISU=id+200
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Special Summon 1 "Shinsen Token" (Aqua/WATER/Level 3/ATK 0/DEF 0) to its controller's opponent's field in Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1:SetTarget(s.shinsensptg)
	e1:SetOperation(s.shinsenspop)
	c:RegisterEffect(e1)
	--Keep track of Special Summoned Effect Monsters
	aux.GlobalCheck(s,function()
		s.regspgroup=Group.CreateGroup()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
	--Destroy both this card and as many Tokens on the field as possible, and if you do, Special Summon 1 "Ebisu Token" (Fairy/WATER/Level 7/ATK ?/DEF ?)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(function(e) return not e:GetHandler():HasFlagEffect(id+100) end)
	e2:SetTarget(s.ebisusptg)
	e2:SetOperation(s.ebisuspop)
	c:RegisterEffect(e2)
end
s.listed_names={TOKEN_SHINSEN,TOKEN_EBISU}
function s.efftgfilter(c,e)
	return c:IsEffectMonster() and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and (not e or c:IsCanBeEffectTarget(e))
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.efftgfilter,nil)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		if Duel.GetCurrentChain()==0 then s.regspgroup:Clear() end
		s.regspgroup:Merge(tg)
		s.regspgroup:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		Duel.RaiseEvent(s.regspgroup,EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.sptgfilter(c,tp)
	local target_player=1-c:GetControler()
	return Duel.GetLocationCount(target_player,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SHINSEN,0,TYPES_TOKEN,0,0,3,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE,target_player)
end
function s.shinsensptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=s.regspgroup:Filter(s.efftgfilter,nil,e):Match(s.sptgfilter,nil,tp)
	if chkc then return g:IsContains(chkc) and s.efftgfilter(chkc,e) end
	if chk==0 then return #g>0 end
	local tc=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=g:Select(tp,1,1,nil):GetFirst()
	else
		tc=g:GetFirst()
	end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.shinsenspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local target_player=1-tc:GetControler()
		if Duel.GetLocationCount(target_player,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SHINSEN,0,TYPES_TOKEN,0,0,3,RACE_AQUA,ATTRIBUTE_WATER,POS_FACEUP_DEFENSE,target_player) then
			local token=Duel.CreateToken(tp,TOKEN_SHINSEN)
			Duel.SpecialSummon(token,0,tp,target_player,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
function s.ebisusptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_TOKEN)
	if chk==0 then return #g>0 and Duel.GetMZoneCount(tp,g)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_EBISU,0,TYPES_TOKEN,-2,-2,7,RACE_FAIRY,ATTRIBUTE_WATER) end
	local c=e:GetHandler()
	c:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g+c,#g+1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.ebisuspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_TOKEN)
	if #g==0 then return end
	local des_ct=Duel.Destroy(g+c,REASON_EFFECT)
	local atk_def_val=(des_ct-1)*700
	if des_ct>=2 and Duel.GetOperatedGroup():IsContains(c)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_EBISU,0,TYPES_TOKEN,atk_def_val,atk_def_val,7,RACE_FAIRY,ATTRIBUTE_WATER) then
		local token=Duel.CreateToken(tp,TOKEN_EBISU)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			--This Token's ATK/DEF become the number of Tokens destroyed by this effect x 700
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(atk_def_val)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE)
			token:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
	end
end